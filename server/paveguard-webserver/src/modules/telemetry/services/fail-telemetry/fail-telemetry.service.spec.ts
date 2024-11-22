import { Test, TestingModule } from '@nestjs/testing';
import { FailTelemetryService } from './fail-telemetry.service';

describe('FailTelemetryService', () => {
  let service: FailTelemetryService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [FailTelemetryService],
    }).compile();

    service = module.get<FailTelemetryService>(FailTelemetryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
