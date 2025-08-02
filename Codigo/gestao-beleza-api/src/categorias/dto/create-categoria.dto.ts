import { IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";

export class CreateCategoriaDto {
    @IsNotEmpty({ message: 'O nome da categoria não pode estar vazio.' })
    @IsString()
    nome: string;

    @IsOptional()
    @IsNumber()
    ordem_exibicao?: number;
}