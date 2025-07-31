import { IsBoolean, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateServicoDto {
  @IsNotEmpty({ message: 'O nome do serviço não pode estar vazio.' })
  @IsString()
  nome: string;

  @IsOptional()
  @IsString()
  descricao?: string;

  @IsNotEmpty({ message: 'O preço é obrigatório.' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  preco: number;

  @IsNotEmpty({ message: 'A duração em minutos é obrigatória.' })
  @IsInt()
  @Min(1)
  duracao_minutos: number;

  @IsOptional()
  @IsBoolean()
  esta_ativo?: boolean;

  @IsOptional()
  @IsInt()
  id_categoria?: number;
}