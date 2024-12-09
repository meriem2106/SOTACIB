import { Test, TestingModule } from '@nestjs/testing';
import { VisiteController } from './visite.controller';

describe('VisiteController', () => {
  let controller: VisiteController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VisiteController],
    }).compile();

    controller = module.get<VisiteController>(VisiteController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
