// src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app/app.module';
import { ValidationPipe } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { ServiceAccount } from 'firebase-admin';
import * as path from 'path';

async function bootstrap() {
  try {
    const serviceAccountPath = path.resolve(
      __dirname,
      '../../',
      'firebase-service-account.json',
    );
    const serviceAccount: ServiceAccount = require(serviceAccountPath);

    console.log('Firebase Admin SDK: Tentando inicializar...'); // <-- ESTA LINHA

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log('Firebase Admin SDK: Inicializado com sucesso!'); // <-- E ESTA LINHA
  } catch (error) {
    console.error('ERRO CRÍTICO AO INICIALIZAR O FIREBASE ADMIN SDK:', error);
    process.exit(1);
  }

  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe());
  await app.listen(3000);
}
bootstrap();