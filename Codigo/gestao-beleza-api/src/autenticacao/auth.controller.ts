import { Controller, Get, Req, UnauthorizedException, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../autenticacao/firebase-auth.guard';
import { Request } from 'express';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @UseGuards(FirebaseAuthGuard) 
  @Get('profile')
  getProfile(@Req() req: Request) {

    if(!req.user) {
      throw new UnauthorizedException('Usuário não encontrado no token.');
    }
    
    // req.user agora é populado pela nossa FirebaseStrategy
    // com os dados { firebase_uid, email, id_pessoa, nome }
    const id_pessoa = req.user.id_pessoa;

    // Chamamos o novo método do nosso serviço para buscar os dados completos
    return this.authService.getDadosPerfil(id_pessoa);
  }
}
