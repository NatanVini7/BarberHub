import { ConflictException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RegisterDto } from '../autenticacao/dto/register.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) { }

  async create(registerDto: RegisterDto) {
    const userExists = await this.prisma.usuarios.findUnique({
      where: { email: registerDto.email },
    });

    if (userExists) {
      throw new ConflictException('Este email já está em uso.');
    }

    const salt = await bcrypt.genSalt();
    const hashedPassword = await bcrypt.hash(registerDto.senha, salt);

    const pessoa = await this.prisma.pessoas.create({
      data: {
        nome_completo: registerDto.nome_completo,
        usuario: {
          create: {
            email: registerDto.email,
            senha: hashedPassword,
          },
        },
      },
      include: {
        usuario: true,
      },
    });

    if (pessoa.usuario) {
      const { senha, ...usuarioSemSenha } = pessoa.usuario;
      const resultadoFinal = {
        ...pessoa,
        usuario: usuarioSemSenha,
      };

      return resultadoFinal;
    }
    return pessoa;
  }
}
