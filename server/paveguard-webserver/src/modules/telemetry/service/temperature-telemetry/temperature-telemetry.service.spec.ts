import { Test, TestingModule } from '@nestjs/testing';
import { TemperatureTelemetryService } from './temperature-telemetry.service';

describe('TemperatureTelemetryServiceService', () => {
  let service: TemperatureTelemetryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TemperatureTelemetryService],
    }).compile();

    service = module.get<TemperatureTelemetryService>(TemperatureTelemetryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
