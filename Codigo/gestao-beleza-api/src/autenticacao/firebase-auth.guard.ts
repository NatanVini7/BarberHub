import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    if (!token) {
      throw new UnauthorizedException('Token de autorização não fornecido.');
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);

      if (!decodedToken.email) {
        throw new UnauthorizedException('O token não contém um email.');
      }
      
      // A variável agora pode ser do tipo correto ou nula
      let usuarioEncontrado = await this.prisma.usuarios.findUnique({
        where: { email: decodedToken.email },
        include: { pessoa: true },
      });

      // Se o usuário não existir, nós o criamos
      if (!usuarioEncontrado) {
        const novaPessoa = await this.prisma.pessoas.create({
          data: {
            nome_completo: decodedToken.name || 'Nome não fornecido',
            usuario: {
              create: {
                email: decodedToken.email,
                senha: `firebase_auth_${Date.now()}`,
              },
            },
          },
          include: { usuario: true },
        });

        if (!novaPessoa.usuario) {
            throw new Error('Falha ao criar usuário associado.');
        }

        // --- CORREÇÃO APLICADA AQUI ---
        // Em vez de atribuir apenas o usuário, montamos o objeto completo
        // para que ele tenha a mesma estrutura do 'findUnique' com 'include'.
        usuarioEncontrado = {
            ...novaPessoa.usuario, // Copia todas as propriedades do usuário (id, email, senha, etc)
            pessoa: novaPessoa,   // Aninha o objeto da pessoa recém-criada
        };
      }
      
      if (!usuarioEncontrado.pessoa) {
        throw new Error('Usuário existe, mas não está associado a uma pessoa.');
      }

      // Anexamos o perfil do nosso banco de dados ao objeto da requisição
      request.user = {
        firebase_uid: decodedToken.uid,
        email: usuarioEncontrado.email,
        id_pessoa: usuarioEncontrado.id_pessoa,
        nome: usuarioEncontrado.pessoa.nome_completo,
      };

    } catch (error) {
      console.error('Falha na autenticação do Firebase Guard:', error);
      throw new UnauthorizedException('Falha na autenticação. Token inválido ou expirado.');
    }
    
    return true;
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    // É importante importar o 'Request' do express para ter acesso aos headers
    // import { Request } from 'express';
    const [type, token] = request.headers['authorization']?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
