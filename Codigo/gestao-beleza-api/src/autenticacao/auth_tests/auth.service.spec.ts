import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../../prisma/prisma.service';
import { NotFoundException } from '@nestjs/common';
import { pessoas_tipo_documento } from '@prisma/client';

// Criamos um objeto mock que simula o PrismaService e suas funções
const mockPrismaService = {
  pessoas: {
    findUnique: jest.fn(),
  },
  vinculos: {
    findMany: jest.fn(),
  },
};

describe('AuthService', () => {
  let service: AuthService;
  let prisma: PrismaService;

  // O bloco `beforeEach` é executado antes de cada teste
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: PrismaService, // Sempre que alguém pedir o PrismaService...
          useValue: mockPrismaService, // ...entregue nosso objeto mock no lugar.
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  // Limpa os mocks após cada teste para evitar que um teste influencie o outro
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getProfileData', () => {

    // TESTE 1: O "caminho feliz", onde o usuário é encontrado
    it('should return user profile data for a valid user id', async () => {
      // Arrange (Preparação): Definimos os dados falsos que o Prisma deveria retornar
      const id_pessoa = 1;
      const mockPessoa = {
        id: 1,
        nome_completo: 'Usuário de Teste',
        documento: '12345678900',
        tipo_documento: pessoas_tipo_documento.CPF,
        data_nascimento: new Date('1990-01-01'),
        criado_em: new Date(),
        atualizado_em: new Date(),
      };
      const mockVinculos = [
        {
          perfil: 'cliente',
          estabelecimento: { id: 10, nome_fantasia: 'Salão A' },
        },
      ];

      // Configuramos os mocks para retornarem nossos dados falsos
      jest.spyOn(prisma.pessoas, 'findUnique').mockResolvedValue(mockPessoa);
      jest.spyOn(prisma.vinculos, 'findMany').mockResolvedValue(mockVinculos as any);

      // Act (Ação): Executamos o método que queremos testar
      const result = await service.getProfileData(id_pessoa);

      // Assert (Verificação): Verificamos se o resultado é o esperado
      expect(result).toEqual({
        id: mockPessoa.id,
        nome_completo: mockPessoa.nome_completo,
        documento: mockPessoa.documento,
        data_nascimento: mockPessoa.data_nascimento,
        vinculos: mockVinculos,
      });

      // Verificamos se os métodos do prisma foram chamados corretamente
      expect(prisma.pessoas.findUnique).toHaveBeenCalledWith({
        where: { id: id_pessoa },
      });
      expect(prisma.vinculos.findMany).toHaveBeenCalledWith({
        where: { id_pessoa: id_pessoa },
        select: {
          perfil: true,
          estabelecimento: {
            select: {
              id: true,
              nome_fantasia: true,
            },
          },
        },
      });
    });

    // TESTE 2: O "caminho triste", onde o ID do usuário não existe
    it('should throw NotFoundException if pessoa is not found', async () => {
      // Arrange (Preparação): Configuramos o mock para retornar nulo, simulando um usuário não encontrado
      const id_pessoa = 999;
      jest.spyOn(prisma.pessoas, 'findUnique').mockResolvedValue(null);

      // Act & Assert (Ação e Verificação):
      // Verificamos se a chamada ao método REJEITA a promessa e lança a exceção correta.
      await expect(service.getProfileData(id_pessoa)).rejects.toThrow(
        NotFoundException,
      );

      // Verificamos também se o método do prisma foi chamado
      expect(prisma.pessoas.findUnique).toHaveBeenCalledWith({
        where: { id: id_pessoa },
      });
    });
  });
});