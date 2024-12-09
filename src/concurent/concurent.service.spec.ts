import { Test, TestingModule } from '@nestjs/testing';
import { ConcurentService } from './concurent.service';

describe('ConcurentService', () => {
  let service: ConcurentService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ConcurentService],
    }).compile();

    service = module.get<ConcurentService>(ConcurentService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
