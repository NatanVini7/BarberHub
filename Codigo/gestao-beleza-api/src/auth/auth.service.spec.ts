import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, pass: string): Promise<any> {
    const user = await this.prisma.usuarios.findUnique({
      where: { email },
      include: { pessoa: true }, // Inclui os dados da pessoa
    });

    if (user && (await bcrypt.compare(pass, user.senha))) {
      const { senha, ...result } = user;
      return result;
    }
    return null;
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.senha);
    if (!user) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }

    // O payload do token pode conter qualquer informação que você queira
    const payload = {
      sub: user.id_pessoa, // 'sub' é o padrão para o ID do sujeito (usuário)
      email: user.email,
      nome: user.pessoa.nome_completo,
    };

    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
