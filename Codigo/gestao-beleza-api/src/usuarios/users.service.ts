import { ConflictException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RegisterDto } from '../autenticacao/dto/register.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) { }

  async create(registerDto: RegisterDto) {
    // Verifica se o email já existe
    const userExists = await this.prisma.usuarios.findUnique({
      where: { email: registerDto.email },
    });

    if (userExists) {
      throw new ConflictException('Este email já está em uso.');
    }

    // Criptografa a senha antes de salvar
    const salt = await bcrypt.genSalt();
    const hashedPassword = await bcrypt.hash(registerDto.senha, salt);

    // O Prisma permite criar registros relacionados em uma única transação,
    // o que garante a consistência dos dados.
    const pessoa = await this.prisma.pessoas.create({
      data: {
        nome_completo: registerDto.nome_completo,
        // Cria o usuário associado a esta pessoa
        usuario: {
          create: {
            email: registerDto.email,
            senha: hashedPassword,
          },
        },
      },
      // Inclui os dados do usuário recém-criado na resposta
      include: {
        usuario: true,
      },
    });

    // Verifica se 'usuario' existe para satisfazer o TypeScript
    if (pessoa.usuario) {
      // Usa a desestruturação para separar a senha do resto do objeto
      const { senha, ...usuarioSemSenha } = pessoa.usuario;

      // Cria um objeto de resposta final, combinando 'pessoa' com o 'usuario' sem a senha
      const resultadoFinal = {
        ...pessoa,
        usuario: usuarioSemSenha,
      };

      return resultadoFinal;
    }

    return pessoa;
  }
}
