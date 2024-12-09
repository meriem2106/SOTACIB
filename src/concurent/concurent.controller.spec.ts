import { Test, TestingModule } from '@nestjs/testing';
import { ConcurentController } from './concurent.controller';

describe('ConcurentController', () => {
  let controller: ConcurentController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ConcurentController],
    }).compile();

    controller = module.get<ConcurentController>(ConcurentController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
