import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UsersModule } from '../users/users.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { JwtStrategy } from './jwt.strategy';

@Module({
  imports: [
    UsersModule, // Importa o UsersModule para ter acesso ao UsersService
    PassportModule,
    JwtModule.register({
      secret: '31122001', // !! IMPORTANTE: Mude isso e coloque em uma variável de ambiente !!
      signOptions: { expiresIn: '1d' }, // Token expira em 1 dia
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy], // Adicionaremos a JwtStrategy aqui depois
})
export class AuthModule {}
