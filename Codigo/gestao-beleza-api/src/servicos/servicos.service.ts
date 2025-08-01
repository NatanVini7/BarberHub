import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'prisma/prisma.service';
import { CreateServicoDto } from './dto/create-servico.dto';
import { UpdateServicoDto } from './dto/update-servico.dto';

@Injectable()
export class ServicosService {
    constructor(private prisma: PrismaService) { }

    findAll(id_estabelecimento: number) {
        return this.prisma.servicos.findMany({
            where: { id_estabelecimento: id_estabelecimento },
            include: {
                categoria: {
                    select: { nome: true },
                }
            },
        });
    }

    async findOne(id: number, id_estabelecimento: number) {
        const servico = await this.prisma.servicos.findUnique({
            where: { id: id },
        });

        if (!servico || servico?.id_estabelecimento !== id_estabelecimento) {
            throw new NotFoundException(`Serviço com ID ${id} não encontrado`)
        }
        return servico;
    }

    async create(createServicoDto: CreateServicoDto, id_estabelecimento: number) {
        return this.prisma.servicos.create({
            data: {
                ...createServicoDto,
                id_estabelecimento,
            }
        });
    }

    async update(id: number, updateServicoDto: UpdateServicoDto, id_estabelecimento: number) {
        await this.findOne(id, id_estabelecimento);
        return this.prisma.servicos.update({
            where: { id: id },
            data: updateServicoDto,
        });
    }

    async remove(id: number, id_estabelecimento: number) {
        await this.findOne(id, id_estabelecimento);
        return this.prisma.servicos.delete({
            where: { id: id },
        });
    }
}

