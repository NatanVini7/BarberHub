import { IsBoolean, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from "class-validator";

export class CreateProdutoDto {
    @IsNotEmpty({ message: 'O nome do produto não pode estar vazio.' })
    @IsString()
    nome: string;

    @IsOptional()
    @IsString()
    descricao?: string;

    @IsOptional()
    @IsString()
    codigo_barras?: string;
    
    @IsNotEmpty({ message: 'O preço de venda é obrigatório' })
    @IsNumber({ maxDecimalPlaces: 2 })
    @Min(0)
    preco_venda: number;

    @IsOptional()
    @IsNumber({ maxDecimalPlaces: 2 })
    @Min(0)
    preco_custo?: number;

    @IsOptional()
    @IsInt()
    @Min(0)
    quantidade_estoque?: number;

    @IsOptional()
    @IsInt()
    @Min(0)
    estoque_minimo?: number;

    @IsOptional()
    @IsBoolean()
    esta_ativo?: boolean;
}