import { Test, TestingModule } from '@nestjs/testing';
import { DynamicGuardService } from './dynamic-guard.service';

describe('DynamicGuardService', () => {
  let service: DynamicGuardService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [DynamicGuardService],
    }).compile();

    service = module.get<DynamicGuardService>(DynamicGuardService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
