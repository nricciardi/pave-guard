import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';
import { TemperatureTelemetryService } from '../services/temperature-telemetry/temperature-telemetry.service';
import { TelemetryQuery } from './telemetry.resolver';


@ObjectType()
export class TemperatureTelemetryQuery extends TelemetryQuery {

  @Field()
  temperature: number;
}


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
    @Args() input: CreateTemperatureTelemetryDto,
  ) {
    return this.temperatureTelemetryService.create(input);
  }
}

