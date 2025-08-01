import { Test, TestingModule } from '@nestjs/testing';
import { EstabelecimentosService } from './estabelecimentos.service';

describe('EstabelecimentosService', () => {
  let service: EstabelecimentosService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [EstabelecimentosService],
    }).compile();

    service = module.get<EstabelecimentosService>(EstabelecimentosService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
