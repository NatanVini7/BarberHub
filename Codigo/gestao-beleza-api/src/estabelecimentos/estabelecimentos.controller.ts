import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import { EstabelecimentosService } from './estabelecimentos.service';
import { CreateEstabelecimentoDto } from './dto/create-estabelecimento.dto';
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
}
