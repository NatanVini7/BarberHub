import { Controller, UnauthorizedException, UseGuards, Get, Post, Delete, Patch, Param, Req, Body, ParseIntPipe, ForbiddenException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ProdutosService } from './produtos.service';
import { Request } from 'express';
import { PrismaService } from 'prisma/prisma.service';
import { CreateProdutoDto } from './dto/create-produto.dto';
import { UpdateProdutoDto } from './dto/update-produto.dto';
import { FirebaseAuthGuard } from '../autenticacao/firebase-auth.guard';

@UseGuards(FirebaseAuthGuard)
@Controller('produtos')
export class ProdutosController {
    constructor(
        private readonly produtosService: ProdutosService,
        private readonly prisma: PrismaService,
    ) {}

    private async getUserEstablishmentId(req: Request): Promise<number> {
        const id_pessoa = req.user?.id_pessoa;
        const vinculo = await this.prisma.vinculos.findFirst({
            where: {
                id_pessoa: id_pessoa,
                perfil: { in: ['admin', 'profissional'] },
            },
        });

        if(!vinculo) {
            throw new UnauthorizedException('Você não tem perminssão para gerenciar estabelecimentos.');
        }
        return vinculo.id_estabelecimento;
    }

    @Post()
    async create(@Body() createProdutoDto: CreateProdutoDto, @Req() req: Request) {
        const id_estabelecimento = await this.getUserEstablishmentId(req);
        return this.produtosService.create(createProdutoDto, id_estabelecimento);
    }

    @Get()
    async findAll(@Req() req: Request) {
        const id_estabelecimento = await this.getUserEstablishmentId(req);
        return this.produtosService.findAll(id_estabelecimento);
    }

    @Get(':id')
    async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
        const id_estabelecimento = await this.getUserEstablishmentId(req);
        return this.produtosService.findOne(id, id_estabelecimento)
    }

    @Patch(':id')
    async update(@Param('id', ParseIntPipe) id: number, @Body() updateProdutoDto: UpdateProdutoDto, @Req() req: Request) {
        const id_estabelecimento = await this.getUserEstablishmentId(req);
        return this.produtosService.update(id, updateProdutoDto, id_estabelecimento);
    }

    @Delete(':id')
    async delete(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
        const id_estabelecimento = await this.getUserEstablishmentId(req);
        const vinculo = await this.prisma.vinculos.findFirst({ where: { id_pessoa: req.user?.id_pessoa } });
        if(vinculo?.perfil !== 'admin') {
            throw new ForbiddenException('Apenas administradores podem apagar produtos.');
        }
        return this.produtosService.remove(id, id_estabelecimento);
    }
}
