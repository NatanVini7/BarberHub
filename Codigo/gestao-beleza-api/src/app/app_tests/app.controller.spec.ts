import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from 'src/autenticacao/auth.controller';
import { AuthService } from 'src/autenticacao/auth.service';
import { PrismaService } from '../../../prisma/prisma.service';

describe('AuthController', () => {
  let controller: AuthController;

  // Criamos mocks para todos os serviços que o controller precisa
  const mockAuthService = {
    getProfileData: jest.fn(() => {
      return { id: 1, nome: 'Usuário Teste' };
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        // Agora, o teste sabe como criar o AuthService
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
        // O AuthService precisa do Prisma, então também precisamos simular o Prisma aqui,
        // mesmo que não o usemos diretamente no teste do controller.
        {
          provide: PrismaService,
          useValue: {}, // Pode ser um objeto vazio
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});