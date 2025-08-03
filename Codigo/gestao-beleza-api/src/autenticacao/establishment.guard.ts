import {CanActivate, ExecutionContext, Injectable, ForbiddenException,} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class EstablishmentGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Pega o ID do estabelecimento da URL (ex: /estabelecimentos/2/servicos)
    const establishmentId = parseInt(request.params.idEstabelecimento, 10);

    if (!user || !user.id_pessoa || !establishmentId) {
      // Se não houver usuário ou ID do estabelecimento, bloqueia o acesso
      return false;
    }

    const vinculo = await this.prisma.vinculos.findFirst({
      where: {
        id_pessoa: user.id_pessoa,
        id_estabelecimento: establishmentId,
        perfil: { in: ['admin', 'profissional'] },
      },
    });

    if (!vinculo) {
      throw new ForbiddenException(
        'Você не tem permissão para acessar este estabelecimento.',
      );
    }
    return true;
  }
}
