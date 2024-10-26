import { Test, TestingModule } from '@nestjs/testing';
import { TelemetryController } from './telemetry-controller.controller';

describe('TelemetryControllerController', () => {
  let controller: TelemetryController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TelemetryController],
    }).compile();

    controller = module.get<TelemetryController>(TelemetryController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
