import { Test, TestingModule } from '@nestjs/testing';
import { GouvernoratController } from './gouvernorat.controller';

describe('GouvernoratController', () => {
  let controller: GouvernoratController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [GouvernoratController],
    }).compile();

    controller = module.get<GouvernoratController>(GouvernoratController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
