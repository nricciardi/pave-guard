import { Test, TestingModule } from '@nestjs/testing';
import { StaticGuardService } from './static-guard.service';

describe('StaticGuardService', () => {
  let service: StaticGuardService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [StaticGuardService],
    }).compile();

    service = module.get<StaticGuardService>(StaticGuardService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
