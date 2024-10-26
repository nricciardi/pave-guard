// src/telemetry/telemetry.resolver.ts
import { Resolver, Query, Args } from '@nestjs/graphql';
import { Telemetry } from '../model/telemetry-schema.model';
import { TelemetryService } from '../service/telemetry-service.service';

@Resolver(() => Telemetry)
export class TelemetryResolver {
  constructor(private readonly telemetryService: TelemetryService) {}

  @Query(() => [Telemetry])
  async getAllTelemetry() {
    return this.telemetryService.findAll();
  }
}
