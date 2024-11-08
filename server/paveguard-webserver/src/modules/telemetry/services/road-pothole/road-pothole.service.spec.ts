import { Test, TestingModule } from '@nestjs/testing';
import { RoadPotholeService } from './road-pothole.service';

describe('RoadPotholeService', () => {
  let service: RoadPotholeService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RoadPotholeService],
    }).compile();

    service = module.get<RoadPotholeService>(RoadPotholeService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
