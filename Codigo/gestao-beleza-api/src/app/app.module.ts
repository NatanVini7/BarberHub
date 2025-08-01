import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from 'prisma/prisma.module';
import { AuthModule } from '../autenticacao/auth.module';
import { UsersModule } from '../usuarios/users.module';
import { ServicosModule } from '../servicos/servicos.module';
import { ProdutosModule } from 'src/produtos/produtos.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    UsersModule,
    ServicosModule,
    ProdutosModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
