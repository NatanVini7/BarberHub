import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UsersModule } from '../usuarios/users.module';
import { PassportModule } from '@nestjs/passport';
import { FirebaseStrategy } from './firebase.strategy';

@Module({
  imports: [
    UsersModule,
    PassportModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, FirebaseStrategy],
})
export class AuthModule { }