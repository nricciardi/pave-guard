import { Resolver, Query, Args, Mutation } from '@nestjs/graphql';
import { Telemetry, TelemetryQuery } from '../models/telemetry.model';
import { TelemetryService } from '../service/telemetry/telemetry.service';
import { TemperatureTelemetryService } from '../service/temperature-telemetry/temperature-telemetry.service';

@Resolver(() => TelemetryQuery)
export class TelemetryResolver {
  constructor(
    private readonly telemetryService: TelemetryService,
  ) {}

  @Query(() => [TelemetryQuery])
  async telemetries() {
    return this.telemetryService.findAll();
  }
}
