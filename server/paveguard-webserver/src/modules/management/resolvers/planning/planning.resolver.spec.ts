import { Test, TestingModule } from '@nestjs/testing';
import { PlanningResolver } from './planning.resolver';

describe('PlanningResolver', () => {
  let resolver: PlanningResolver;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PlanningResolver],
    }).compile();

    resolver = module.get<PlanningResolver>(PlanningResolver);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
