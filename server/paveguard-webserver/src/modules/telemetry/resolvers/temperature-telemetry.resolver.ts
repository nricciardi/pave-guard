import { Resolver, Query, Args, Mutation } from '@nestjs/graphql';
import { TelemetryService } from '../service/telemetry/telemetry.service';
import { TemperatureTelemetryQuery } from '../models/temperature-telemetry.model';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';
import { TemperatureTelemetryService } from '../service/temperature-telemetry/temperature-telemetry.service';

@Resolver(() => TemperatureTelemetryQuery)
export class TemperatureTelemetryResolver {
  constructor(
    private readonly temperatureTelemetryService: TemperatureTelemetryService,
  ) {}

  @Query(() => [TemperatureTelemetryQuery])
  async temperatureTelemetries() {
    return this.temperatureTelemetryService.findAll();
  }

  @Mutation(() => TemperatureTelemetryQuery)
  async createTemperatureTelemetry(
    @Args('input') input: CreateTemperatureTelemetryDto,
  ) {
    return this.temperatureTelemetryService.create(input);
  }
}
