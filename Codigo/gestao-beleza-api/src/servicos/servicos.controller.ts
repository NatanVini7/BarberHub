import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, 
    Req, ParseIntPipe, UnauthorizedException, ForbiddenException} from '@nestjs/common';
import { FirebaseAuthGuard } from '../autenticacao/firebase-auth.guard';
import { ServicosService } from './servicos.service';
import { PrismaService } from 'prisma/prisma.service';
import { Request } from 'express';
import { CreateServicoDto } from './dto/create-servico.dto';
import { UpdateServicoDto } from './dto/update-servico.dto';

@UseGuards(FirebaseAuthGuard)
@Controller('servicos')
export class ServicosController {
    constructor(
        private readonly servicosService: ServicosService,
        private readonly prisma: PrismaService,
    ) {}

    private async getIdEstabelecimentoUsuario(req: Request): Promise<number> {
        const id_pessoa = req.user?.id_pessoa;
        const vinculo = await this.prisma.vinculos.findFirst({
            where: {
                id_pessoa: id_pessoa,
                perfil: { in: ['admin', 'profissional']},
            },
        });

        if (!vinculo) {
            throw new UnauthorizedException('Você não tem permissão para gerenciar estabelecimentos.');
        }
        return vinculo.id_estabelecimento;
    }

    @Post()
    async create(@Body() createServicoDto: CreateServicoDto, @Req() req: Request) {
        const id_estabelecimento = await this.getIdEstabelecimentoUsuario(req);
        return this.servicosService.create(createServicoDto, id_estabelecimento);
    }

    @Get()
    async findAll(@Req() req: Request) {
        const id_estabelecimento = await this.getIdEstabelecimentoUsuario(req);
        return this.servicosService.findAll(id_estabelecimento);
    }

    @Get(':id')
    async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
        const id_estabelecimento = await this.getIdEstabelecimentoUsuario(req);
        return this.servicosService.findOne(id, id_estabelecimento);
    }

    @Patch(':id')
    async update(@Param('id', ParseIntPipe) id: number, @Body() updateServicoDto: UpdateServicoDto, @Req() req: Request) {
        const id_estabelecimento = await this.getIdEstabelecimentoUsuario(req);
        return this.servicosService.update(id, updateServicoDto, id_estabelecimento);
    }

    @Delete(':id')
    async remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
        const id_estabelecimento = await this.getIdEstabelecimentoUsuario(req);
        const vinculo = await this.prisma.vinculos.findFirst({ where: { id_pessoa: req.user?.id_pessoa } });

        if(vinculo?.perfil !== 'admin') {
            throw new ForbiddenException('Apenas administradores podem apagar serviços.');
        }
        return this.servicosService.remove(id, id_estabelecimento);
    }   
}
