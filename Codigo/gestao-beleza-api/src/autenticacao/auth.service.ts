import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async getDadosPerfil(id_pessoa: number) {
    const pessoa = await this.prisma.pessoas.findUnique({
      where: { id: id_pessoa },
      include: {
        usuario: {
          select: {
            email: true,
          },
        },
      },
    });

    if (!pessoa) {
      throw new NotFoundException('Pessoa não encontrada.');
    }

    const vinculos = await this.prisma.vinculos.findMany({
      where: { id_pessoa: id_pessoa },
      select: {
        perfil: true,
        estabelecimento: {
          select: {
            id: true,
            nome_fantasia: true,
          },
        },
      },
    });

    return {
      id: pessoa.id,
      nome_completo: pessoa.nome_completo,
      email: pessoa.usuario?.email,
      documento: pessoa.documento,
      data_nascimento: pessoa.data_nascimento,
      vinculos: vinculos,
    };
  }
}