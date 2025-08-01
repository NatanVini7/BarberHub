import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'prisma/prisma.service';
import { CreateProdutoDto } from './dto/create-produto.dto';
import { UpdateProdutoDto } from './dto/update-produto.dto';

@Injectable()
export class ProdutosService {
    constructor(private prisma: PrismaService) {}

    findAll(id_estabelecimento: number) {
        return this.prisma.produtos.findMany({
            where: { id_estabelecimento: id_estabelecimento },
        });
    }

    async findOne(id: number, id_estabelecimento: number) {
        const produto = await this.prisma.produtos.findUnique({
            where: { id: id },
        });

        if(!produto || produto.id_estabelecimento !== id_estabelecimento) {
            throw new NotFoundException(`Produto com ID ${id} não encontrado`);
        }
        return produto;
    }

    create(createProdutoDto: CreateProdutoDto, id_estabelecimento: number) {
        return this.prisma.produtos.create({
            data: {
                ...createProdutoDto,
                id_estabelecimento: id_estabelecimento,
            },
        });
    }

    async update(id: number, updateProdutoDto: UpdateProdutoDto, id_estabelecimento: number) {
        await this.findOne(id, id_estabelecimento);
        return this.prisma.produtos.update({
            where: { id: id },
            data: updateProdutoDto,
        });
    }

    async remove(id:number, id_estabelecimento: number) {
        await this.findOne(id, id_estabelecimento);
        return this.prisma.produtos.delete({
            where: { id: id },
        });
    }
}
