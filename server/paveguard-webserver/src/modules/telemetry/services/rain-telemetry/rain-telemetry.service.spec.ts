import { Test, TestingModule } from '@nestjs/testing';
import { RainTelemetryService } from './rain-telemetry.service';

describe('RainTelemetryService', () => {
  let service: RainTelemetryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RainTelemetryService],
    }).compile();

    service = module.get<RainTelemetryService>(RainTelemetryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
