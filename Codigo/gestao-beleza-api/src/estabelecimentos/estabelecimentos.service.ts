import {Injectable, ConflictException, ForbiddenException, NotFoundException} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateEstabelecimentoDto } from './dto/create-estabelecimento.dto';
import { UpdateEstabelecimentoDto } from './dto/update-estabelecimento.dto';
import { vinculos_perfil } from '@prisma/client';

@Injectable()
export class EstabelecimentosService {
  constructor(private prisma: PrismaService) { }

  async create(dto: CreateEstabelecimentoDto, id_pessoa_gestor: number) {
    return this.prisma.$transaction(async (prisma) => {
      const vinculoExistente = await prisma.vinculos.findFirst({
        where: {
          id_pessoa: id_pessoa_gestor,
          perfil: { in: ['admin', 'profissional'] },
        },
      });

      // Cria o novo estabelecimento
      const novoEstabelecimento = await prisma.estabelecimentos.create({
        data: {
          nome_fantasia: dto.nome_fantasia,
          razao_social: dto.razao_social,
          documento: dto.documento,
        },
      });

      // Cria o vínculo de 'admin' para o usuário
      const novoVinculo = await prisma.vinculos.create({
        data: {
          id_pessoa: id_pessoa_gestor,
          id_estabelecimento: novoEstabelecimento.id,
          perfil: vinculos_perfil.admin,
        },
      });

      return {
        message: 'Estabelecimento criado com sucesso!',
        estabelecimento: novoEstabelecimento,
        vinculo: novoVinculo,
      };
    });
  }

  async findAllForUser(id_pessoa: number) {
    return this.prisma.vinculos.findMany({
      where: { id_pessoa: id_pessoa },
      select: {
        perfil: true,
        estabelecimento: true,
      },
    });
  }

  async findOne(id_estabelecimento: number, id_pessoa: number) {
    const vinculo = await this.prisma.vinculos.findFirst({
      where: {
        id_estabelecimento: id_estabelecimento,
        id_pessoa: id_pessoa,
      },
    });

    if (!vinculo) {
      throw new NotFoundException(
        `Estabelecimento com ID ${id_estabelecimento} não encontrado ou você não tem permissão para acessá-lo.`,
      );
    }

    return this.prisma.estabelecimentos.findUnique({ where: { id: id_estabelecimento } });
  }

  async update(id_estabelecimento: number, dto: UpdateEstabelecimentoDto, id_pessoa: number) {
    const vinculo = await this.prisma.vinculos.findFirst({
      where: { id_estabelecimento: id_estabelecimento, id_pessoa: id_pessoa },
    });

    if (!vinculo) {
      throw new NotFoundException(
        `Estabelecimento com ID ${id_estabelecimento} não encontrado ou você не tem permissão.`,
      );
    }

    if (vinculo.perfil !== 'admin') {
      throw new ForbiddenException(
        'Apenas administradores podem editar os dados do estabelecimento.',
      );
    }

    return this.prisma.estabelecimentos.update({
      where: { id: id_estabelecimento },
      data: dto,
    });
  }

  async remove(id_estabelecimento: number, id_pessoa: number) {
    const vinculo = await this.prisma.vinculos.findFirst({
      where: { id_estabelecimento: id_estabelecimento, id_pessoa: id_pessoa },
    });

    if (!vinculo) {
      throw new NotFoundException(
        `Estabelecimento com ID ${id_estabelecimento} não encontrado ou você не tem permissão.`,
      );
    }

    if (vinculo.perfil !== 'admin') {
      throw new ForbiddenException(
        'Apenas administradores podem apagar um estabelecimento.',
      );
    }

    return this.prisma.estabelecimentos.delete({ where: { id: id_estabelecimento } });
  }
}
