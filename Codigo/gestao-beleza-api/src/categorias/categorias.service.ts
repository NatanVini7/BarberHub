import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'prisma/prisma.service';
import { CreateCategoriaDto } from './dto/create-categoria.dto';
import { UpdateCategoriaDto } from './dto/update-categoria.dto';

@Injectable()
export class CategoriasService {
    constructor(private prisma: PrismaService) {}

    findAll(id_estabelecimento: number) {
        return this.prisma.categorias_servicos.findMany({
            where: { id_estabelecimento: id_estabelecimento },
            orderBy: {
                ordem_exibicao: 'asc' // Ordena pela ordem de exibição
            },
        });
    }

    async findOne(id: number, id_estabelecimento: number) {
        const categoria = await this.prisma.categorias_servicos.findUnique({
            where: { id: id },
        });

        if(!categoria || categoria.id_estabelecimento !== id_estabelecimento) {
            throw new NotFoundException(`Categoria com ID ${id} não encontrada.`);
        }
        return categoria;
    }

    create(createCategoriaDto: CreateCategoriaDto, id_estabelecimento: number) {
        return this.prisma.categorias_servicos.create({
            data: {
                ...createCategoriaDto,
                id_estabelecimento: id_estabelecimento,
            }
        });
    }

    async update(id: number, updateCategoriaDto: UpdateCategoriaDto, id_estabelecimento: number) {
        await this.findOne(id, id_estabelecimento);
        return this.prisma.categorias_servicos.update({
            where: { id: id },
            data: updateCategoriaDto,
        });
    }

    async remove(id: number, id_estabelecimento: number) {
        await this.findOne(id, id_estabelecimento);
        return this.prisma.categorias_servicos.delete({
            where: { id: id },
        });
    }
}
