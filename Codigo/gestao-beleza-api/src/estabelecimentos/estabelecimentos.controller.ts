import { Controller, Post, Body, UseGuards, Req, Get, Param, ParseIntPipe, Patch, Delete } from '@nestjs/common';
import { EstabelecimentosService } from './estabelecimentos.service';
import { CreateEstabelecimentoDto } from './dto/create-estabelecimento.dto';
import { UpdateEstabelecimentoDto } from './dto/update-estabelecimento.dto';
import { FirebaseAuthGuard } from '../autenticacao/firebase-auth.guard';
import { Request } from 'express';

@UseGuards(FirebaseAuthGuard)
@Controller('estabelecimentos')
export class EstabelecimentosController {
  constructor(
    private readonly estabelecimentosService: EstabelecimentosService,
  ) {}

  @Post()
  create(@Body() dto: CreateEstabelecimentoDto, @Req() req: Request) {
    const id_pessoa_gestor = req.user!.id_pessoa;
    return this.estabelecimentosService.create(dto, id_pessoa_gestor);
  }

  @Get()
  findAllForUser(@Req() req: Request) {
    const id_pessoa = req.user!.id_pessoa;
    return this.estabelecimentosService.findAllForUser(id_pessoa);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const id_pessoa = req.user!.id_pessoa;
    return this.estabelecimentosService.findOne(id, id_pessoa);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateEstabelecimentoDto, @Req() req: Request,
  ) {
    const id_pessoa = req.user!.id_pessoa;
    return this.estabelecimentosService.update(id, dto, id_pessoa);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const id_pessoa = req.user!.id_pessoa;
    return this.estabelecimentosService.remove(id, id_pessoa);
  }
}
