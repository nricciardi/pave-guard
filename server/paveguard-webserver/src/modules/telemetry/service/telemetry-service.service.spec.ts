import { Test, TestingModule } from '@nestjs/testing';
import { TelemetryService } from './telemetry-service.service';

describe('TelemetryServiceService', () => {
  let service: TelemetryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TelemetryService],
    }).compile();

    service = module.get<TelemetryService>(TelemetryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
