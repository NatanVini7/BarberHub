import {
    Controller, Get, Post, Body, Patch, Param, Delete, UseGuards,
    Req, ParseIntPipe, UnauthorizedException, ForbiddenException
} from '@nestjs/common';
import { ServicosService } from './servicos.service';
import { PrismaService } from 'prisma/prisma.service';
import { Request } from 'express';
import { CreateServicoDto } from './dto/create-servico.dto';
import { UpdateServicoDto } from './dto/update-servico.dto';
import { EstablishmentGuard } from 'src/autenticacao/establishment.guard';
import { FirebaseAuthGuard } from '../autenticacao/firebase-auth.guard';

@UseGuards(FirebaseAuthGuard, EstablishmentGuard)
@Controller('estabelecimentos/:idEstabelecimento/servicos')
export class ServicosController {
    constructor(
        private readonly servicosService: ServicosService,
        private readonly prisma: PrismaService,
    ) { }

    @Post()
    create(
        @Param('idEstabelecimento', ParseIntPipe) idEstabelecimento: number,
        @Body() createServicoDto: CreateServicoDto,
    ) {
        return this.servicosService.create(createServicoDto, idEstabelecimento);
    }

    @Get()
    findAll(@Param('idEstabelecimento', ParseIntPipe) idEstabelecimento: number) {
        return this.servicosService.findAll(idEstabelecimento);
    }

    @Get(':id')
    findOne(
        @Param('id', ParseIntPipe) id: number,
        @Param('idEstabelecimento', ParseIntPipe) idEstabelecimento: number,
    ) {
        return this.servicosService.findOne(id, idEstabelecimento);
    }

    @Patch(':id')
    update(
        @Param('id', ParseIntPipe) id: number,
        @Param('idEstabelecimento', ParseIntPipe) idEstabelecimento: number,
        @Body() updateServicoDto: UpdateServicoDto,
    ) {
        return this.servicosService.update(id, updateServicoDto, idEstabelecimento);
    }

    @Delete(':id')
    remove(
        @Param('id', ParseIntPipe) id: number,
        @Param('idEstabelecimento', ParseIntPipe) idEstabelecimento: number,
    ) {
        // A lógica de permissão mais fina (admin vs profissional) permanece no service.
        return this.servicosService.remove(id, idEstabelecimento); // TODO: Passar id_pessoa para o service validar a role
    }
}
