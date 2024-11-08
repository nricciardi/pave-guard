import { Test, TestingModule } from '@nestjs/testing';
import { RoadCrackService } from './road-crack.service';

describe('RoadCrackService', () => {
  let service: RoadCrackService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RoadCrackService],
    }).compile();

    service = module.get<RoadCrackService>(RoadCrackService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
