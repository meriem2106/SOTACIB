import { Test, TestingModule } from '@nestjs/testing';
import { GouvernoratService } from './gouvernorat.service';

describe('GouvernoratService', () => {
  let service: GouvernoratService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [GouvernoratService],
    }).compile();

    service = module.get<GouvernoratService>(GouvernoratService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
