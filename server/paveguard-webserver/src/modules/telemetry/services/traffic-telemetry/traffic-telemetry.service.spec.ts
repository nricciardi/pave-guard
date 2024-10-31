import { Test, TestingModule } from '@nestjs/testing';
import { TrafficTelemetryService } from './traffic-telemetry.service';

describe('TrafficTelemetryService', () => {
  let service: TrafficTelemetryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TrafficTelemetryService],
    }).compile();

    service = module.get<TrafficTelemetryService>(TrafficTelemetryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
