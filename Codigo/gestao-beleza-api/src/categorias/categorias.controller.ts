import { Body, Controller, Delete, ForbiddenException, Get, Param, ParseIntPipe, Patch, Post, Req, UnauthorizedException, UseGuards } from '@nestjs/common';
import { CategoriasService } from './categorias.service';
import { PrismaService } from 'prisma/prisma.service';
import { Request } from 'express';
import { CreateCategoriaDto } from './dto/create-categoria.dto';
import { UpdateCategoriaDto } from './dto/update-categoria.dto';
import { FirebaseAuthGuard } from '../autenticacao/firebase-auth.guard';

@UseGuards(FirebaseAuthGuard)
@Controller('categorias')
export class CategoriasController {
    constructor(
        private readonly categoriasService: CategoriasService,
        private readonly prisma: PrismaService,
    ) {}

    private async getUserEstablishmentId(req: Request): Promise<number> {
        const id_pessoa = req.user!.id_pessoa;
        const vinculo = await this.prisma.vinculos.findFirst({
            where: {
                id_pessoa: id_pessoa,
                perfil: { in: ['admin', 'profissional'] },
            },
        });

        if(!vinculo) {
            throw new UnauthorizedException('Você não tem permissão para gerenciar estabelecimentos.');
        }
        return vinculo.id_estabelecimento;
    }

  @Post()
  async create(@Body() createCategoriaDto: CreateCategoriaDto, @Req() req: Request) {
    const id_estabelecimento = await this.getUserEstablishmentId(req);
    return this.categoriasService.create(createCategoriaDto, id_estabelecimento);
  }

  @Get()
  async findAll(@Req() req: Request) {
    const id_estabelecimento = await this.getUserEstablishmentId(req);
    return this.categoriasService.findAll(id_estabelecimento);
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const id_estabelecimento = await this.getUserEstablishmentId(req);
    return this.categoriasService.findOne(id, id_estabelecimento);
  }

  @Patch(':id')
  async update(@Param('id', ParseIntPipe) id: number, @Body() updateCategoriaDto: UpdateCategoriaDto, @Req() req: Request) {
    const id_estabelecimento = await this.getUserEstablishmentId(req);
    return this.categoriasService.update(id, updateCategoriaDto, id_estabelecimento);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const id_estabelecimento = await this.getUserEstablishmentId(req);
    const vinculo = await this.prisma.vinculos.findFirst({ where: { id_pessoa: req.user!.id_pessoa } });
    if (vinculo?.perfil !== 'admin') {
      throw new ForbiddenException('Apenas administradores podem apagar categorias.');
    }
    return this.categoriasService.remove(id, id_estabelecimento);
  }
}
