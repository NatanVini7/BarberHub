import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from 'prisma/prisma.module';
import { AuthModule } from '../autenticacao/auth.module';
import { UsersModule } from '../usuarios/users.module';
import { ServicosModule } from '../servicos/servicos.module';
import { EstabelecimentosModule } from 'src/estabelecimentos/estabelecimentos.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    UsersModule,
    ServicosModule,
    EstabelecimentosModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
