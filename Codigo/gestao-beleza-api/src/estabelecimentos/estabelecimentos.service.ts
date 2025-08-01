import { Injectable, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateEstabelecimentoDto } from './dto/create-estabelecimento.dto';
import { vinculos_perfil } from '@prisma/client';

@Injectable()
export class EstabelecimentosService {
  constructor(private prisma: PrismaService) {}

  async create(
    dto: CreateEstabelecimentoDto,
    id_pessoa_gestor: number,
  ) {
    // Usamos uma transação para garantir a atomicidade da operação.
    // Ou todos os comandos são executados com sucesso, ou nenhum é.
    return this.prisma.$transaction(async (prisma) => {

      // Verificamos se esta pessoa já é dona de outro estabelecimento.
      const vinculoExistente = await prisma.vinculos.findFirst({
        where: { 
          id_pessoa: id_pessoa_gestor,
          perfil: { in: ['admin', 'profissional'] },
        }
      });

      if (vinculoExistente) {
        throw new ConflictException('Este usuário já possui um vínculo profissional ou administrativo.');
      }

      const novoEstabelecimento = await prisma.estabelecimentos.create({
        data: {
          nome_fantasia: dto.nome_fantasia,
          razao_social: dto.razao_social,
          documento: dto.documento,
        },
      });

      // 3. Cria o vínculo, transformando o usuário em 'admin' deste novo estabelecimento
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
}
