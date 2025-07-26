import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class LoginDto {
  @IsNotEmpty({ message: 'O email não pode estar vazio.' })
  @IsEmail({}, { message: 'Por favor, insira um email válido.' })
  email: string;

  @IsNotEmpty({ message: 'A senha не pode estar vazia.' })
  @IsString()
  senha: string;
}
