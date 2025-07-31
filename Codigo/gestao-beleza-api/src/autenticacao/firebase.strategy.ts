import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { Strategy, ExtractJwt } from 'passport-firebase-jwt';
import * as admin from 'firebase-admin';
import { PrismaService } from '../../prisma/prisma.service';
import { usuarios, pessoas } from '@prisma/client';

@Injectable()
export class FirebaseStrategy extends PassportStrategy(Strategy, 'firebase') { // Dê um nome à estratégia
    constructor(private prisma: PrismaService) {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
        });
    }

    async validate(token: admin.auth.DecodedIdToken) {
        //Garantir que as informações essenciais existem no token.
        if (!token.email) {
            throw new UnauthorizedException('O token do Firebase não contém um email.');
        }

        //Tenta encontrar o usuário e a pessoa associada no nosso banco.
        const usuarioEncontrado = await this.prisma.usuarios.findUnique({
            where: { email: token.email },
            include: { pessoa: true }, // Inclui os dados da pessoa na mesma consulta
        });

        let usuarioFinal: usuarios;
        let pessoaFinal: pessoas;

        //Se o usuário não existir no nosso banco, nós criamos.
        if (!usuarioEncontrado) {
            console.log('Usuário não encontrado, criando um novo...');

            const novaPessoa = await this.prisma.pessoas.create({
                data: {
                    // Usa o nome do token ou um valor padrão seguro.
                    nome_completo: token.name || 'Nome não fornecido',
                    usuario: {
                        create: {
                            email: token.email,
                            // A senha não é mais relevante, mas o campo é obrigatório no DB.
                            senha: `firebase_auth_${Date.now()}`,
                        },
                    },
                },
                include: { usuario: true }, // Pede para retornar o usuário criado junto
            });

            // Se o usuário não for criado por algum motivo (pouco provável), lançamos um erro.
            if (!novaPessoa.usuario) {
                throw new Error('Falha ao criar o registro de usuário associado à pessoa.');
            }

            pessoaFinal = novaPessoa;
            usuarioFinal = novaPessoa.usuario;

        } else {
            // Se o usuário já existe, apenas usamos os dados encontrados.
            pessoaFinal = usuarioEncontrado.pessoa;
            usuarioFinal = usuarioEncontrado;
        }

        //Retorna um objeto limpo e consistente que será o `req.user`.
        // Este objeto agora tem todas as informações necessárias para os controllers.
        return {
            firebase_uid: token.uid,
            email: usuarioFinal.email,
            id_pessoa: pessoaFinal.id,
            nome: pessoaFinal.nome_completo,
        };
    }
}
