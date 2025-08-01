import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateEstabelecimentoDto {
  @IsNotEmpty({ message: 'O nome fantasia é obrigatório.' })
  @IsString()
  nome_fantasia: string;

  @IsOptional()
  @IsString()
  razao_social?: string;

  @IsOptional()
  @IsString()
  documento?: string;
}
