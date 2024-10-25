import { Test, TestingModule } from '@nestjs/testing';
import { TelemetryControllerController } from './telemetry-controller.controller';

describe('TelemetryControllerController', () => {
  let controller: TelemetryControllerController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TelemetryControllerController],
    }).compile();

    controller = module.get<TelemetryControllerController>(TelemetryControllerController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
