import { Test, TestingModule } from '@nestjs/testing';
import { HumidityTelemetryService } from './humidity-telemetry.service';

describe('HumidityTelemetryService', () => {
  let service: HumidityTelemetryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [HumidityTelemetryService],
    }).compile();

    service = module.get<HumidityTelemetryService>(HumidityTelemetryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
