// src/telemetry/temperature-telemetry.resolver.ts
import { Resolver, Mutation, Args } from '@nestjs/graphql';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';
import { TemperatureTelemetry } from '../models/temperature-telemetry-schema.model';
import { TemperatureTelemetryService } from '../service/temperature-telemetry-service.service';

@Resolver(() => TemperatureTelemetry)
export class TemperatureTelemetryResolver {
  constructor(private readonly temperatureTelemetryService: TemperatureTelemetryService) {}

  @Mutation(() => TemperatureTelemetry)
  async createTemperatureTelemetry(
    @Args('input') input: CreateTemperatureTelemetryDto,
  ) {
    return this.temperatureTelemetryService.create(input);
  }
}