import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: '31122001', // !! Use a mesma chave secreta do auth.module !!
    });
  }

  // O Passport decodifica o token e nos entrega o payload que criamos no login
  async validate(payload: any) {
    // O objeto retornado aqui será anexado ao objeto `request` do Express (request.user)
    return {
      id_pessoa: payload.sub,
      email: payload.email,
      nome: payload.nome,
    };
  }
}
